mod commands;

#[cfg(test)]
mod tests;

use anyhow::Result;
use clap::Parser;
use commands::{Cli, handle_command};

fn main() -> Result<()> {
    let cli = Cli::parse();
    
    if let Err(e) = handle_command(cli) {
        eprintln!("Error: {}", e);
        std::process::exit(1);
    }

    Ok(())
}
