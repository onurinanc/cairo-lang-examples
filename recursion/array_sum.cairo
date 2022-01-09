%builtins output

from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.alloc import alloc

func array_sum(array : felt*, size : felt) -> (sum : felt):
    if size == 0:
        return (sum = 0)
    end

    let (current_sum) = array_sum(array = array + 1, size = size -1)
    return (sum = [array] + current_sum)
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

    let (sum) = array_sum(arr, 10)
    serialize_word(sum)
    return()
end