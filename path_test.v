module path

import os

fn test_clean_path() {
	path1 := '//././../path/to/./file.v/.'
	path2 := 'path/to/./file.v/.'
	path3 := '//./path/./././file.v/.////'
	path4 := '//././//.././..//'
	path5 := '/'

	if is_win {
		assert clean_path(path1) == r'\..\path\to\file.v'
		assert clean_path(path2) == r'path\to\file.v'
		assert clean_path(path3) == r'\path\file.v'
		assert clean_path(path4) == r'\..\..'
		assert clean_path(path5) == r'\'
		return
	}
	assert clean_path(path1) == '/../path/to/file.v'
	assert clean_path(path2) == 'path/to/file.v'
	assert clean_path(path3) == '/path/file.v'
	assert clean_path(path4) == r'/../..'
	assert clean_path(path5) == r'/'
}

fn test_is_abs() {
	if is_win {
		assert is_abs('/path\\to\\file.v')
		assert !is_abs('path\\to\\file.v')
		assert !is_abs('D:path/to/file.v')
		assert is_abs('C:\\path/to/file.v')
		assert is_abs(r'\\?\Device\path\to\file.v')
		assert !is_abs(r'\\?\')
		assert !is_abs(r'\\.')
		assert !is_abs(r'\\.\\\\')
		assert is_abs(r'\\Host\Share\path\to\file.v')
		assert is_abs(r'\\Host\Share')
		assert !is_abs(r'\\Host\')
		assert !is_abs('')
		assert is_abs('/')
		return
	}
	assert is_abs('/path/to/file.v')
	assert !is_abs('\\path/to/file.v')
	assert is_abs('/path/to/dir')
	assert !is_abs('')
	assert !is_abs('\\')
}

fn test_norm_path() {
	if is_win {
		assert norm_path(r'C:/path/to//file.v\\') == r'C:\path\to\file.v'
		assert norm_path(r'C:path\.\..\\\.\to//file.v') == r'C:to\file.v'
		assert norm_path(r'D:path\.\..\..\\\\.\to//dir/..\') == r'D:..\to'
		assert norm_path(r'D:/path\.\..\/..\file.v') == r'D:\file.v'
		assert norm_path(r'') == '.'
		assert norm_path(r'/') == '\\'
		assert norm_path(r'\/') == '\\'
		assert norm_path(r'path\../dir\..') == '.'
		assert norm_path(r'.\.\') == '.'
		assert norm_path(r'G:.\.\dir\././\.\.\\\\///to/././\file.v/./\\') == r'G:dir\to\file.v'
		assert norm_path(r'G:\..\..\.\.\file.v\\\.') == r'G:\file.v'
		assert norm_path(r'\\Server\share\\\dir/..\file.v\./.') == r'\\Server\share\file.v'
		assert norm_path(r'\\.\device\\\dir/to/./file.v\.') == r'\\.\device\dir\to\file.v'
		return
	}
	assert norm_path('/path/././../to/file//file.v/.') == '/to/file/file.v'
	assert norm_path('path/././to/files/../../file.v/.') == 'path/file.v'
	assert norm_path('path/././/../../to/file.v/.') == '../to/file.v'
	assert norm_path('/path/././/../..///.././file.v/././') == '/file.v'
	assert norm_path('path/../dir/..') == '.'
	assert norm_path('../dir/..') == '..'
	assert norm_path('/../dir/..') == '/'
	assert norm_path('//././dir/../files/././/file.v') == '/files/file.v'
	assert norm_path('/\\../dir/////////.') == '/\\../dir'
}

fn test_abs_path() {
	wd := os.getwd()
	wd_w_sep := wd + sep
	if is_win {
		assert abs_path('path/to/file.v') == r'${wd_w_sep}path\to\file.v'
		assert abs_path('path/to/file.v') == r'${wd_w_sep}path\to\file.v'
		assert abs_path('/') == '\\'
		assert abs_path('files') == '${wd_w_sep}files'
		assert abs_path('') == wd
		assert abs_path('files/../file.v') == '${wd_w_sep}file.v'
		assert abs_path('///') == '\\'
		assert abs_path('/path/to/file.v') == r'\path\to\file.v'
		assert abs_path('/') == '\\'
		return
	}
	assert abs_path('/') == '/'
	assert abs_path('.') == wd
	assert abs_path('files') == '${wd_w_sep}files'
	assert abs_path('') == wd
	assert abs_path('files/../file.v') == '${wd_w_sep}file.v'
	assert abs_path('///') == '/'
	assert abs_path('/path/to/file.v') == '/path/to/file.v'
	assert abs_path('/path/to/file.v/../..') == '/path'
}
