// Copyright (c) 2022 Ben Larisch All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module path

import strings
import os

const (
	is_win = os.user_os() == 'windows'
	bslash_bslash = r'\\'
	fslash = `/`
	bslash = `\\`
	dot =  `.`
	dot_dot = '..'
	empty = ''
)

pub const sep = get_os_sep()

// norm_path normalizes the given `path` by
// resolving backlinks (..), turning forward slashes
// into back slashes on a Windows system and eliminating:
// - references to current (.) directory
// - redundant spaces and path separators
// - the last path separator
pub fn norm_path(path string) string {
	if path.len == 0 { return '.' }
	p := path.trim_space()
	if p.len == 0 { return '.' }
	rooted := is_abs(p)
	head_len := if is_win { win_drive_len(p) } else { 0 }
	head := to_bslashes(p[..head_len])
	cpath := clean_path(p[head_len..])
	cpath_len := cpath.len
	if cpath_len == 0 && head_len == 0 { 
		return '.'
	}
	spath := cpath.split(sep)
	if dot_dot !in spath {
		return if head_len != 0 { 
			head + cpath 
		} else { 
			cpath 
		}
	}
	// resolve backlinks (..)
	spath_len := spath.len 
	mut sb := strings.new_builder(cpath_len)
	if rooted { sb.write_string(sep) }
	mut new_path := []string{cap: spath_len}
	mut b_link := 0
	for i := spath_len - 1; i >= 0; i-- {
		el := spath[i]
		if el == empty { continue }
		if el == dot_dot {
			b_link++
			continue
		}
		if b_link != 0 {
			b_link--
			continue
		}
		new_path.prepend(el)
	}
	// append backlink(s) to the path if backtracking
	// is not possible and the given path is not rooted
	if b_link != 0 && !rooted {
		for i in 0..b_link {
			sb.write_string(dot_dot) 
			if new_path.len == 0 && i == b_link - 1 { 
				break 
			}
			sb.write_string(sep)
		}
	}
	sb.write_string(new_path.join(sep))
	res := sb.str()
	if res.len == 0 {
		return match true {
			head_len != 0 { head }
			!rooted { '.' }
			else { sep }
		}
	}
	if head_len != 0 {
		return head + res 
	}
	return res
}

// is_abs returns `true` if the given `path` is absolute.
pub fn is_abs(path string) bool {
	if path.len == 0 { return false }
	if is_win {
		return is_unc_path(path) 
		|| win_drive_rooted(path)
		|| win_rooted(path)
	}
	return is_sep(path[0])
}

// `abs_path` joins the current working directory 
// with the passed `path` (if the `path` is relative)
// and returns the absolute path representation. 
pub fn abs_path(path string) string {
	wd := os.getwd()
	return match true {
		path.len == 0 { wd }
		is_abs(path) { norm_path(path) }
		else { norm_path(wd + sep + path) }  
	}
}

// clean_path "cleans" the path by turning forward slashes
// into back slashes on a Windows system and eliminating:
// - references to current (.) directories
// - redundant path separators
// - the last path separator
fn clean_path(path string) string {
	plen := path.len
	if plen == 0 { return '' }
	mut sb := strings.new_builder(plen)
	for i := 0; i < plen; i++ {
		b := path[i]
		// skip path sep if the last byte was a path sep
		if i - 1 >= 0 && is_sep(path[i - 1]) && is_sep(b) {
			continue
		}
		// skip reference to current dir (.)
		if (i - 1 == -1 || is_sep(path[i - 1]))
		&& b == dot
		&& (i + 1 == plen || is_sep(path[i + 1])) {
			// skip next path sep
			if i + 1 < plen && is_sep(path[i + 1]) {
				i++
			}
			continue
		}
		sb.write_u8(path[i])
	}
	res := if is_win { to_bslashes(sb.str()) } else { sb.str() }
	// eliminate last path sep
	res_len := res.len 
	if res_len > 1 && is_sep(res[res_len - 1]) {
		return res[..res_len - 1]
	}
	return res
}

// get_os_sep returns the path separator
// based on the current operating system.
fn get_os_sep() string {
	return if is_win {
		bslash.str() 
	} else { 
		fslash.str() 
	}
}

fn to_bslashes(s string) string {
	if s.len == 0 { return s.clone() }
	return s.replace('/', '\\')
}

fn is_sep(b u8) bool {
	return b == fslash || (is_win && b == bslash)
}

fn is_unc_path(path string) bool {
	if path.len < 5 { return false }
	return win_drive_len(path) >= 5 
	&& is_sep(path[0]) 
	&& is_sep(path[1]) 
}

fn win_drive_rooted(path string) bool {
	if path.len < 3 { return false }
	return has_win_drive_letter(path) && is_sep(path[2])
}

fn win_rooted(path string) bool {
	plen := path.len
	if plen == 0 { return false }
	return is_sep(path[0]) 
	&& (plen == 1 || (plen >= 2 && !is_sep(path[1])))
}
