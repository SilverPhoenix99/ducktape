class Array
  include Ducktape::Hookable

  make_hooks %w'clear
    compact!
    concat
    delete
    delete_at
    delete_if
    fill
    flatten!
    insert
    keep_if
    map!
    pop
    push
    reject!
    replace
    reverse!
    rotate!
    select!
    shift
    shuffle!
    slice!
    sort!
    sort_by!
    uniq!
    unshift',
    '<<'       => 'append',
    '[]='      => 'store',
    'collect!' => 'map!'
end