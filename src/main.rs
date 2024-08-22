use std::{fs, path::PathBuf};

use clap::Parser;
use mkhelp::Document;

#[derive(Parser)]
#[command(version, about, long_about = None)]
struct Cli {
    /// Location of makefile
    #[arg(default_value = "Makefile")]
    src: PathBuf,
}

fn main() {
    let args = Cli::parse();
    let text = fs::read_to_string(args.src).unwrap();
    let doc: Document = text.parse().unwrap();
    println!("{}", doc.help())
}
