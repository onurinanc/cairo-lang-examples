%builtins output

from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.alloc import alloc

# THe following function will compute [arr]*[arr+2]*...
func mult_even_entries(array : felt*, size : felt) -> (mult : felt):
    if size == 0:
        return (mult = 1)
    end

    let (current_mult) = mult_even_entries(array = array + 2, size = size -2)
    return (mult = [array] * current_mult)
end

func main{output_ptr: felt*}():
    let (arr: felt*) = alloc()
    
    assert([arr]) = 1
    assert([arr + 1]) = 2
    assert([arr + 2]) = 3
    assert([arr + 3]) = 4
    assert([arr + 4]) = 5
    assert([arr + 5]) = 6
    assert([arr + 6]) = 7
    assert([arr + 7]) = 8
    assert([arr + 8]) = 9
    assert([arr + 9]) = 10

    let (mult) = mult_even_entries(arr, 10)
    
    serialize_word(mult)
    return()
end