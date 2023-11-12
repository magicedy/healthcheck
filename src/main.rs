use hyper::{Client, Uri};
use hyper::http::StatusCode;
use std::env;
use std::process;
use tokio::time::{timeout, Duration};

#[tokio::main]
async fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() < 2 {
        eprintln!("Error: URL is required. Specify a URL as the first argument.");
        process::exit(1);
    }

    let url = &args[1].parse::<Uri>().expect("Invalid URL");

    match timeout(Duration::from_secs(5), check_health(url)).await {
        Ok(result) => match result {
            Ok(_) => {
                println!("OK: {}", url);
            }
            Err(e) => {
                eprintln!("Error calling healthcheck: {}", e);
                process::exit(1);
            }
        },
        Err(e) => {
            eprintln!("Timeout：{}", e);
            process::exit(1);
        }
    }
}

async fn check_health(url: &Uri) -> Result<(), String> {
    let client = Client::new();

    let res = client.get(url.clone()).await.map_err(|e| e.to_string())?;

    if res.status() != StatusCode::OK {
        let err_msg = format!("Bad healthcheck status: {}", res.status());
        eprintln!("{}", &err_msg);
        return Err(err_msg);
    }
    Ok(())
}
