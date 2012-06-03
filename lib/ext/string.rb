class String
  include Ducktape::Hookable

  make_hooks %w'concat
    capitalize!
    chomp!
    chop!
    clear
    delete!
    downcase!
    encode!
    force_encoding
    gsub!
    insert
    lstrip!
    next!
    prepend
    replace
    reverse!
    rstrip!
    setbyte
    slice!
    squeeze!
    strip!
    sub!
    swapcase!
    tr!
    tr_s!
    upcase!',
    '<<'    => 'concat',
    '[]='   => 'store',
    'succ!' => 'next!'
end