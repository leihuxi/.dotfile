#pacman help
pach() {
	echo "pacman-disowned           \"Find third party install\""
	echo "pacownbypkg package       \"Listing files owned by a package with size\""
	echo "pacnf                     \"Removing unused packages\""
	echo "pacnotbase                \"Find package not base or base-level\""
	echo "pacsize                   \"Find package with size\""
	echo "pacownsize                \"Find package with size by owner\""
	echo "pacdep package            \"Getting the dependencies list of several packages\""
	echo "pacetc                    \"Listing changed backup files\""
	echo "pacallinstall             \"List of installed packages\""
	echo "pacchg                    \"Listing all changed files from packages\""
	echo "pacreinstall              \"Reinstalling all packages\""
    echo "pacoldlib                 \"Use old lib app\""
}

# Find third party install
pacman-disowned() {
    tmp=${TMPDIR-/tmp}/pacman-disowned-$UID-$$
    db=$tmp/db
    fs=$tmp/fs

    mkdir "$tmp"
    trap  'rm -rf "$tmp"' EXIT

    pacman -Qlq | sort -u > "$db"

    sudo find /bin /etc /lib /sbin /usr \
        ! -name lost+found \
        \( -type d -printf '%p/\n' -o -print \) | sort > "$fs"

    comm -23 "$fs" "$db"
}

# Listing files owned by a package with size
pacownbypkg() {
	pacman -Qlq $1 | grep -v '/$' | xargs du -h | sort -h
}

# Removing unused packages
pacnf() {
    sudo pacman -Rs $(pacman -Qtdq)
}

# Latest install
paclastinstall() {
    if [[ $# -lt 2 ]]; then
        echo "paclr <num>"
    fi
    expac --timefmt='%Y-%m-%d %T' '%l\t%n' | sort | tail -n "$1"
}

# Find packages not base or base-devel
pacnotbase() {
    expac -H M "%011m\t%-20n\t%10d" $(comm -23 <(pacman -Qqen | sort) <(pacman -Qqg base base-devel | sort)) | sort -n
}

# Find packages with size
pacsize() {
    if [[ $# -eq 1 ]]; then
        expac -S -H M '%k\t%n' "$1"
    else
        expac -S -H M '%k\t%n' | sort -h
    fi
}

# Find packages with size by user
pacownsize() {
    expac -H M '%m\t%n' | sort -h
}

# Getting the dependencies list of several packages
pacdep() {
	expac -l '\n' %E -S "$1" | sort -u
}

# Listing changed backup files
pacetc() {
	pacman -Qii | awk '/^MODIFIED/ {print $2}'
}

# List of installed packages
pacallinstall() {
    pacman -Qqe 
}

# Listing all changed files from packages
pacchg() {
    sudo paccheck --md5sum --quiet
}

# Reinstalling all packages
pacreinstall() {
    pacman -Qqn | sudo pacman -S -
}

# Use old lib app
pacoldlib() {
	lsof +c 0 | grep -w DEL | awk '1 { print $1 ": " $NF }' | sort -u
}
