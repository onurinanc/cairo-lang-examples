# There is a database, which includes TC, and the vaccination status
# We'll get these kvp value from the database
# Then, for the unique keys, we will return 0 or 1 as a vaccination status

%builtins output range_check

from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.math import assert_nn_le


struct KeyValue:
    member key: felt
    member value: felt
end

func output_kvp{output_ptr : felt*}(kvp : KeyValue*, n_tcs):
    if n_tcs == 0:
        return()
    end

    serialize_word(kvp.key)
    serialize_word(kvp.value)

    return output_kvp(kvp = kvp + KeyValue.SIZE, n_tcs = n_tcs - 1) 
end

func get_value_by_key{range_check_ptr}(kvp : KeyValue*, key, size) -> (value):
    alloc_locals
    local idx

    %{
        ENTRY_SIZE = ids.KeyValue.SIZE
        KEY_OFFSET = ids.KeyValue.key
        VALUE_OFFSET = ids.KeyValue.value

        for i in range(ids.size):
            addr = ids.kvp.address_ + ENTRY_SIZE * i + KEY_OFFSET

            if memory[addr] == ids.key:
                ids.idx = i
                break

        else:
            raise Exception("Key was not found in the database")

    %}

    let item : KeyValue = kvp[idx]
    assert item.key = key

    assert_nn_le(a = idx, b = size - 1)
    
    return(value = item.value)
end

func main{output_ptr : felt*, range_check_ptr}():
    alloc_locals 

    local n_tcs
    local kvp : KeyValue*

    %{
        tcs = program_input['tc_list']
        status = program_input['vaccination_status_list']

        ids.n_tcs = len(tcs)
        ids.kvp = kvp = segments.add()
        
        for i in range(ids.n_tcs):
            memory[kvp + 2*i] = tcs[i]
            memory[kvp + 2*i + 1] = status[i]
    %}

    #output_kvp(kvp = kvp, n_tcs = n_tcs)

    #let (verification_status) = get_value_by_key(kvp = kvp, key = 11111111112, size = n_tcs)
    #let (verification_status) = get_value_by_key(kvp = kvp, key = 22222222222, size = n_tcs)
    let (verification_status) = get_value_by_key(kvp = kvp, key = 15566688996, size = n_tcs)
    #let (verification_status) = get_value_by_key(kvp = kvp, key = 22258557994, size = n_tcs)
    serialize_word(verification_status)
    assert verification_status = 1

    return()
end