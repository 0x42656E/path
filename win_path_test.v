module path

fn test_win_drive_len() {
	if !is_win { return }
	assert win_drive_len(r'C:\path\to\file.v') == 2
	assert win_drive_len(r'\path\to\file.v') == 0
	assert win_drive_len(r'\\Host\share\to\file.v') == 12
	assert win_drive_len(r'\\.\c:\path\to\file.v') == 6
	assert win_drive_len(r'\\?\BootPartition\path') == 17
	assert win_drive_len(r'//Server/') == 0
}
