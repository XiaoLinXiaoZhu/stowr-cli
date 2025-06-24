use anyhow::Result;
use clap::{Parser, Subcommand};
use std::path::PathBuf;

use stowr_core::{Config, StorageManager, create_index};

#[derive(Parser)]
#[command(name = "stowr")]
#[command(about = "A dynamic file compression and storage tool")]
#[command(version = "0.1.0")]
pub struct Cli {
    #[command(subcommand)]
    pub command: Commands,
}

#[derive(Subcommand)]
pub enum Commands {
    /// Manage configuration settings
    Config {
        /// Configuration key to set
        key: Option<String>,
        /// Configuration value to set
        value: Option<String>,
        /// List all configuration settings
        #[arg(long)]
        list: bool,
    },    /// Store files in the system
    Store {
        /// File to store
        file: Option<PathBuf>,
        /// Read file paths from a list file
        #[arg(long)]
        list: Option<PathBuf>,
        /// Delete source files after storing
        #[arg(long)]
        del: bool,
    },/// Extract files from storage (owe)
    Owe {
        /// File to extract
        file: Option<PathBuf>,
        /// Read file paths from a list file
        #[arg(long)]
        list: Option<PathBuf>,
        /// Extract all stored files
        #[arg(long)]
        all: bool,
    },
    /// Rename a file in storage
    Rename {
        /// Current file name
        old_name: PathBuf,
        /// New file name
        new_name: PathBuf,
    },
    /// Move a file to a new location
    Move {
        /// File to move
        file: PathBuf,
        /// New location
        new_location: PathBuf,
    },
    /// Delete a file from storage
    Delete {
        /// File to delete
        file: PathBuf,
    },    /// List all stored files
    List,
    /// Search for stored files using glob patterns
    Search {
        /// Glob pattern to search for
        pattern: String,
    },
    /// Show version information
    Version,
}

pub fn handle_command(cli: Cli) -> Result<()> {
    match cli.command {
        Commands::Config { key, value, list } => {
            handle_config(key, value, list)
        }        Commands::Store { file, list, del } => {
            handle_store(file, list, del)
        }Commands::Owe { file, list, all } => {
            handle_owe(file, list, all)
        }
        Commands::Rename { old_name, new_name } => {
            handle_rename(old_name, new_name)
        }
        Commands::Move { file, new_location } => {
            handle_move(file, new_location)
        }
        Commands::Delete { file } => {
            handle_delete(file)
        }        Commands::List => {
            handle_list()
        }
        Commands::Search { pattern } => {
            handle_search(pattern)
        }
        Commands::Version => {
            handle_version()
        }
    }
}

fn handle_config(key: Option<String>, value: Option<String>, list: bool) -> Result<()> {
    let mut config = Config::load()?;

    if list {
        println!("Current configuration:");
        for (k, v) in config.list() {
            println!("  {} = {}", k, v);
        }
        return Ok(());
    }

    match (key, value) {
        (Some(k), Some(v)) => {
            config.set(&k, &v)?;
            config.save()?;
            println!("Configuration updated: {} = {}", k, v);
        }
        (Some(k), None) => {
            for (config_key, config_value) in config.list() {
                if config_key == k {
                    println!("{} = {}", config_key, config_value);
                    return Ok(());
                }
            }
            println!("Configuration key not found: {}", k);
        }
        (None, None) => {
            println!("Usage: stowr config <key> <value> or stowr config --list");
        }
        _ => unreachable!(),
    }

    Ok(())
}

fn handle_store(file: Option<PathBuf>, list: Option<PathBuf>, delete_source: bool) -> Result<()> {
    let config = Config::load()?;
    let index = create_index(&config)?;
    let mut storage = StorageManager::new(config, index);

    match (file, list) {
        (Some(f), None) => {
            storage.store_file(&f, delete_source)?;
        }
        (None, Some(l)) => {
            storage.store_files_from_list(&l, delete_source)?;
        }
        _ => {
            println!("Usage: stowr store <file> or stowr store --list <file>");
        }
    }

    Ok(())
}

fn handle_owe(file: Option<PathBuf>, list: Option<PathBuf>, all: bool) -> Result<()> {
    let config = Config::load()?;
    let index = create_index(&config)?;
    let mut storage = StorageManager::new(config, index);

    match (file, list, all) {
        (Some(f), None, false) => {
            storage.owe_file(&f)?;
        }
        (None, Some(l), false) => {
            storage.owe_files_from_list(&l)?;
        }
        (None, None, true) => {
            storage.owe_all_files()?;
        }
        _ => {
            println!("Usage: stowr owe <file> or stowr owe --list <file> or stowr owe --all");
        }
    }

    Ok(())
}

fn handle_rename(old_name: PathBuf, new_name: PathBuf) -> Result<()> {
    let config = Config::load()?;
    let index = create_index(&config)?;
    let mut storage = StorageManager::new(config, index);

    storage.rename_file(&old_name, &new_name)?;
    Ok(())
}

fn handle_move(file: PathBuf, new_location: PathBuf) -> Result<()> {
    let config = Config::load()?;
    let index = create_index(&config)?;
    let mut storage = StorageManager::new(config, index);

    storage.move_file(&file, &new_location)?;
    Ok(())
}

fn handle_delete(file: PathBuf) -> Result<()> {
    let config = Config::load()?;
    let index = create_index(&config)?;
    let mut storage = StorageManager::new(config, index);

    storage.delete_file(&file)?;
    Ok(())
}

fn handle_list() -> Result<()> {
    let config = Config::load()?;
    let index = create_index(&config)?;
    let storage = StorageManager::new(config, index);

    let files = storage.list_files()?;
    
    if files.is_empty() {
        println!("No files stored.");
        return Ok(());
    }

    println!("Stored files:");
    println!("{:<50} {:<12} {:<12} {:<20}", "File", "Original", "Compressed", "Created");
    println!("{}", "-".repeat(94));

    for entry in files {
        let compression_ratio = if entry.file_size > 0 {
            format!("{:.1}%", (entry.compressed_size as f64 / entry.file_size as f64) * 100.0)
        } else {
            "N/A".to_string()
        };

        println!("{:<50} {:<12} {:<12} {:<20}", 
                 entry.original_path.display(),
                 format_bytes(entry.file_size),
                 format!("{} ({})", format_bytes(entry.compressed_size), compression_ratio),
                 entry.created_at.split('T').next().unwrap_or(&entry.created_at));
    }

    Ok(())
}

fn handle_version() -> Result<()> {
    println!("stowr {}", env!("CARGO_PKG_VERSION"));
    println!("A dynamic file compression and storage tool");
    Ok(())
}

fn handle_search(pattern: String) -> Result<()> {
    let config = Config::load()?;
    let index = create_index(&config)?;
    let storage = StorageManager::new(config, index);

    let files = storage.search_files(&pattern)?;
    
    if files.is_empty() {
        println!("No files found matching pattern: {}", pattern);
        return Ok(());
    }

    println!("Files matching pattern '{}' ({} found):", pattern, files.len());
    println!("{:<50} {:<12} {:<12} {:<20}", "File", "Original", "Compressed", "Created");
    println!("{}", "-".repeat(94));

    for entry in files {
        let compression_ratio = if entry.file_size > 0 {
            format!("{:.1}%", (entry.compressed_size as f64 / entry.file_size as f64) * 100.0)
        } else {
            "N/A".to_string()
        };

        println!("{:<50} {:<12} {:<12} {:<20}", 
                 entry.original_path.display(),
                 format_bytes(entry.file_size),
                 format!("{} ({})", format_bytes(entry.compressed_size), compression_ratio),
                 entry.created_at.split('T').next().unwrap_or(&entry.created_at));
    }

    Ok(())
}

pub fn format_bytes(bytes: u64) -> String {
    const UNITS: &[&str] = &["B", "KB", "MB", "GB", "TB"];
    let mut size = bytes as f64;
    let mut unit_index = 0;

    while size >= 1024.0 && unit_index < UNITS.len() - 1 {
        size /= 1024.0;
        unit_index += 1;
    }

    if unit_index == 0 {
        format!("{} {}", bytes, UNITS[unit_index])
    } else {
        format!("{:.1} {}", size, UNITS[unit_index])
    }
}
