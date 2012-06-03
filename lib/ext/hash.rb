class Hash
  include Ducktape::Hookable

  make_hooks %w'clear
    default=
    default_proc=
    delete
    delete_if
    keep_if
    merge!
    rehash
    reject!
    replace
    select!
    shift
    store',
    '[]='    => 'store',
    'update' => 'merge!'
end