Wrapping collections
--------------------

```
# single line less than 80 characters
my_array = [ 1, 2, 3 ]
MyMethod.call(:a => 'a', :b => 'b')

# longer than 80 characters
# note the trailing comma after the last element

my_array = [
  on_var,
  two_var,
  red_var,
  blue_var,
  one_last_really_really_long_var,
]

message = Message.create!({
  :board_id => board.id,
  :subject => 'text',
  :content => 'text',
  :parent_id => 1,
})

BINDING_MEMBERS = Set.new([
  BUILTIN_ADMINISTRATOR,
  BUILTIN_CORE_MEMBER,
  BUILTIN_MEMBER,
])
```

Assigning to results of blocks
------------------------------
```
result = if something
  'a'
else
  'b'
end
```


Private code
------------

```
class MyClass

  def my_public_method
    puts 'public!'
  end

  private

  def my_private_method
    puts 'private!'
  end

end
```
