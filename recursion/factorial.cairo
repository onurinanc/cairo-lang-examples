%builtins output

from starkware.cairo.common.serialize import serialize_word

func factorial(n : felt) -> (fact : felt):
    if n == 0:
        return (fact = 1)
    end

    let (current_fact) = factorial(n = n - 1)
    return (fact = current_fact * n)
end


func main{output_ptr : felt*}():
    let (result) = factorial(5)
    serialize_word(result)
    return()
end