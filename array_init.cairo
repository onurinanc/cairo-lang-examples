%builtins output

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.serialize import serialize_word

func main{output_ptr : felt*}():    
    let (new_array : felt*) = alloc() # init dynamic array
    
    assert[new_array] = 1 # set 0^th element 1
    assert[new_array + 1] = 1
    assert[new_array + 2] = 2
    assert[new_array + 3] = 3

    serialize_word([new_array]) # get 0^th element
    serialize_word([new_array + 1])
    serialize_word([new_array + 2])
    serialize_word([new_array + 3])

    return()
end