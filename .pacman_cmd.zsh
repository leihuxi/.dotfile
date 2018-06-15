#third party install
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

pacnf() {
    sudo pacman -Rs $(pacman -Qtdq)
}

#latest install
paclr() {
    if [[ $# -lt 2 ]]; then
        echo "paclr <num>"
    fi
    expac --timefmt='%Y-%m-%d %T' '%l\t%n' | sort | tail -n "$1"
}

#not base or base-devel
pacnb() {
    expac -H M "%011m\t%-20n\t%10d" $(comm -23 <(pacman -Qqen | sort) <(pacman -Qqg base base-devel | sort)) | sort -n
}

pacsize() {
    if [[ $# -eq 1 ]]; then
        expac -S -H M '%k\t%n' "$1"
    else
        expac -S -H M '%k\t%n'
    fi
}

pacclear() {
    pacman -Rs $(comm -23 <(pacman -Qeq|sort) <((for i in $(pacman -Qqg base); do pactree -ul $i; done)|sort -u|cut -d ' ' -f 1))
}

paci() {
    pacman -Qq |grep -Fv -f <(pacman -Qqm)
}
