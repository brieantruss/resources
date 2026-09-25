# `grep` Command Cheat Sheet

`grep` (*Global Regular Expression Print*) searches plain-text data sets for lines that match a regular expression or pattern.

---

## 1. Syntax & Core Basics

```bash
grep [options] "pattern" [file...]
command | grep [options] "pattern"
```

| Command | Description |
| :--- | :--- |
| `grep "error" app.log` | Search for exact string `"error"` in `app.log` |
| `grep -i "error" app.log` | Case-insensitive search (`ERROR`, `Error`, `error`) |
| `grep -w "is" file.txt` | Match whole words only (prevents matching `this` or `island`) |
| `grep -v "info" app.log` | **Invert match**: print all lines that do **not** match `"info"` |
| `grep -x "exact line" file.txt` | Match whole lines exactly |

---

## 2. Navigating Output & Line Metadata

| Command | Description |
| :--- | :--- |
| `grep -n "fail" auth.log` | Show line numbers alongside matching lines |
| `grep -c "fail" auth.log` | Count the total number of matching lines |
| `grep -o "[0-9]\{1,3\}\.[0-9]\{1,3\}" log.txt` | Print **only** the matched parts of a line (not whole lines) |
| `grep -m 5 "GET" access.log` | Stop reading after `5` matching lines |
| `grep --color=auto "error" app.log` | Highlight matches with color |

---

## 3. Context Control (Lines Before / After)

Essential for logs and inspecting stack traces.

| Option / Command | Description |
| :--- | :--- |
| `grep -B 3 "NullPointerException" app.log` | Show **3 lines Before** the match |
| `grep -A 5 "NullPointerException" app.log` | Show **5 lines After** the match |
| `grep -C 2 "NullPointerException" app.log` | Show **2 lines of Context** (before and after) |
| `grep -2 "pattern" file.txt` | Shorthand for `-C 2` |

---

## 4. Multi-File & Recursive Search

| Command | Description |
| :--- | :--- |
| `grep -r "TODO" ./src` | Search recursively through subdirectories (follows symlinks) |
| `grep -R "TODO" ./src` | Search recursively without following symlinks |
| `grep -l "main" *.c` | List **only filenames** that contain matches |
| `grep -L "license" *.py` | List files that do **not** contain matches |
| `grep -H "config" *.env` | Always print the filename with output line (default for multi-file) |
| `grep -h "config" *.env` | Suppress filename prefix in output |

### Filtering Files and Folders
```bash
# Include only specific file extensions
grep -r --include="*.js" "api_endpoint" ./src

# Exclude specific files
grep -r --exclude="*.min.js" "var" ./src

# Exclude directories (e.g., node_modules, .git)
grep -r --exclude-dir={"node_modules",".git","dist"} "fetch" .
```

---

## 5. Regular Expressions: Basic (BRE) vs Extended (ERE)

* Standard `grep` uses Basic Regular Expressions (`BRE`). Characters like `+`, `?`, `|`, `{}` must be escaped (`\+`, `\|`).
* Use `grep -E` (or `egrep`) for Extended Regular Expressions (`ERE`), where metacharacters do not require escaping.

| Pattern | Engine | Meaning |
| :--- | :--- | :--- |
| `^start` | Both | Line starts with `start` |
| `end$` | Both | Line ends with `end` |
| `^$` | Both | Match blank lines |
| `.` | Both | Any single character except newline |
| `[a-z]` | Both | Any character in range `a` to `z` |
| `[^0-9]` | Both | Any character **not** in range `0-9` |
| `a*` | Both | Zero or more occurrences of `a` |
| `a\+` or `grep -E "a+"` | BRE vs ERE | One or more occurrences of `a` |
| `a\?` or `grep -E "a?"` | BRE vs ERE | Zero or one occurrence of `a` |
| `foo\|bar` or `grep -E "foo|bar"` | BRE vs ERE | Match `foo` **OR** `bar` |
| `[0-9]\{3\}` or `grep -E "[0-9]{3}"` | BRE vs ERE | Exactly 3 occurrences |

---

## 6. Perl-Compatible Regular Expressions (`grep -P`)

`grep -P` enables PCRE syntax for lookarounds and shorthand character classes.

| Shorthand | Meaning | Example |
| :--- | :--- | :--- |
| `\d` | Any digit (`[0-9]`) | `grep -P "\d{4}-\d{2}-\d{2}" access.log` |
| `\D` | Any non-digit | `grep -P "\D+" file.txt` |
| `\s` | Any whitespace (`\t`, `\n`, space) | `grep -P "\s+" file.txt` |
| `\S` | Non-whitespace | `grep -P "\S+" file.txt` |
| `\b` | Word boundary | `grep -P "\btest\b" file.txt` |
| `(?<=foo)bar` | Positive lookbehind: match `bar` preceded by `foo` | `grep -oP "(?<=id=)\d+" url.txt` |

---

## 7. Fast Fixed-String Search (`grep -F` or `fgrep`)

When you want literal text matches without regex overhead (much faster on large files):

```bash
# Treats dots, brackets, and stars literally without escaping:
grep -F "192.168.1.1" access.log
grep -F "[DEBUG]" app.log

# Read fixed patterns from a file (one pattern per line):
grep -F -f blocklist.txt traffic.log
```

---

## 8. Practical Real-World Recipes

### Stripping Comments and Empty Lines
```bash
# Filter out empty lines and bash-style comments (#):
grep -Ev "^(#|$|\s*#)" /etc/nginx/nginx.conf
```

### Extracting IP Addresses
```bash
grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}" /var/log/auth.log
```

### Multiple Patterns (OR condition)
```bash
grep -E "(404|500|502)" access.log
```

### Multiple Patterns (AND condition via pipe)
```bash
grep "POST" access.log | grep "500"
```

### Inspecting Processes
```bash
# Avoid matching the grep command itself:
ps aux | grep "[n]ginx"
```

### Counting Unique Matching Patterns
```bash
grep -oE "HTTP/[0-9.]+ [0-9]{3}" access.log | sort | uniq -c | sort -nr
```

---

## 9. Quick Flag Summary

| Flag | Meaning | Flag | Meaning |
| :---: | :--- | :---: | :--- |
| `-i` | Ignore case | `-A N` | $N$ lines after |
| `-v` | Invert match | `-B N` | $N$ lines before |
| `-w` | Match whole word | `-C N` | $N$ lines context |
| `-n` | Show line numbers | `-E` | Extended regex (`egrep`) |
| `-c` | Count lines | `-F` | Fixed strings (`fgrep`) |
| `-l` | Files with matches | `-P` | Perl regex |
| `-r` | Recursive | `-o` | Show match only |