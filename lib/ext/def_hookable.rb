module Ducktape

  @hookable_types = {}

  def self.def_hookable(klass, *args)
    return if args.length == 0

    names_hash = args.last.is_a?(Hash) ? args.pop : {}

    # reversed merge because names_hash has priority
    @hookable_types[klass] = Hash[args.flatten.map { |v| [v, v] }].merge!(names_hash)

    nil
  end

  def self.hookable(obj)
    return obj if obj.is_a?(Hookable)
    m = obj.class.ancestors.find { |c| @hookable_types.has_key?(c) }
    return obj unless m
    (class << obj; include Hookable; self end).make_hooks(m)
    obj
  end

  def_hookable Array,
    %w'clear
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

  def_hookable Hash,
    %w'clear
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

  def_hookable String,
    %w'concat
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