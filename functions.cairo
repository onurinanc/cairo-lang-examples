%builtins output

from starkware.cairo.common.serialize import serialize_word

func add1(y: felt) -> (y: felt):
    let y = y + 1
    return(y)
end

func add1_square(x: felt) -> (x:felt):
    let (z) = add1(y=x)
    return (x = z * z)
end


func main{output_ptr : felt*}():
    let (res) = add1_square(x=12)
    assert res = (12 + 1) * (12 + 1)
    serialize_word(res)
    return()
end