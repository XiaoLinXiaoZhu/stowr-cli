#[cfg(test)]
mod tests {
    use stowr_core::{Config, StorageManager, create_index};
    use crate::commands::format_bytes;

    #[test]
    fn test_config_creation() {
        let config = Config::default();
        assert!(!config.storage_path.as_os_str().is_empty());
    }

    #[test]
    fn test_glob_to_regex() {
        let config = Config::default();
        let index = create_index(&config).unwrap();
        let storage = StorageManager::new(config, index);
        
        let regex = storage.glob_to_regex("*.txt").unwrap();
        assert!(regex.contains("[^/\\\\]*"));
        assert!(regex.starts_with("^"));
        assert!(regex.ends_with("$"));
    }

    #[test]
    fn test_format_bytes() {
        assert_eq!(format_bytes(1024), "1.0 KB");
        assert_eq!(format_bytes(1048576), "1.0 MB");
        assert_eq!(format_bytes(500), "500 B");
    }
}
