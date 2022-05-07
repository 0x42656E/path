// Copyright (c) 2022 Ben Larisch All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module path

// win_drive_len returns the length 
// of the Windows drive or volume.
fn win_drive_len(path string) int {
	plen := path.len
	if plen < 2 { return 0 }
	if has_win_drive_letter(path) {
		return 2
	}
	// its UNC path / DOS device path?
	if is_win_device_path(path) {
		for i := 3; i < plen; i++ {
			// until first slash:
			// - if UNC path: its host name
			// - if DOS device path: its the path modifier
			if is_sep(path[i]) {
				if (i + 1 < plen && is_sep(path[i + 1])) || i + 1 >= plen {
					break
				}
				i++
				// until second slash:
				// - if UNC path: its share name
				// - if DOS device path: its the device name
				for ; i < plen; i++ {
					if is_sep(path[i]) {
						return i
					}
				}
				return i
			}
		}
	}
	return 0
}

// has_win_drive_letter returns `true` if 
// the given `path` begins with a Windows drive letter.
fn has_win_drive_letter(path string) bool {
	if path.len < 2 { return false }
	if path[0].is_letter() && path[1] == `:` {
		return true
	}
	return false
}

// is_win_device_path returns `true` if the given `path`
// is the beginning of a UNC path or DOS device path.
fn is_win_device_path(path string) bool {
	if path.len < 5 { return false }
	if is_sep(path[0]) && is_sep(path[1]) && path[2] != bslash {
		return true
	}
	return false
}
