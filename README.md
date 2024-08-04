## Simple JS Function Compiler in Ruby

This is based off Gary Bernhardt's Destroy All Software screencast, ["A Compiler
from
Scratch"](https://www.destroyallsoftware.com/screencasts/catalog/a-compiler-from-scratch).

`compiler.rb` compiles a Ruby-esque method into a JavaScript function. It reads
the Ruby-esque method from `compiler-test-file.src` and prints out the
JavaScript.

That's all it does. Don't try to put anything more complicated in
`compiler-test-file.src`. I pretty much copied what was done in the screencast
as a helpful exercise to learn about the structure of compilers generally.

## To run

- Make sure you have Ruby installed. This was run on Ruby version 3.1.0.
- Make `compiler.rb` executable.

```sh
chmod u+x compiler.rb
```

- Put the Ruby-esque method in `compiler-test-file.src`. Examples taken from the
  screencast include the following.

```
def f ()
 1
end
```

```
def f(x,y) g(x) end
```

```
def f(x,y) g(x,y,1) end
```

```
def f(x, y) add(x, y) end
```

```
def f(x, y) add(100, add(10, add(x, y))) end
```

- Run the executable file and observe the output JavaScript

```sh
./compiler.rb
```

- To execute the JavaScript, pipe the output to `node`

```sh
./compiler.rb | node
```

## Additional notes from the screencast

- Note similarity between parser and generator
  - parse_expr => pars_call => parse_args_exprs => parse_expr => parse_call => etc, to an arbitrary depth
    vs
  - generator, which keeps calling itself over and over again
    - There is matching recursion in parser and code generator
- Generator crawls over parse tree
