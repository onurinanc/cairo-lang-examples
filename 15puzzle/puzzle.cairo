# Here is a Cairo program verifying a solution to 15 puzzle
# There will be a loc_list and a tiles_list, initial_state to "print" for the verifier
# What we need to check?
# 1 Verifying a single location is valid 
# 2 Verifying adjacent locations
# 3 Verifying location list
# 4 Building a dict list for the tiles, which are 3, 7, 8, 12
# 5 Creating the final state
# 6 Creating initial state using squash_dict 
# 7 Outputting initial state for the verifier
# 8 Checking the solution.
# 
# verify_valid_location(loc : Location*):
# verify_adjacent_location(loc0 : Location*, loc1 : Location*): 
# verify_location_list(loc_list : Location*, n_steps : felt):
#
# build_dict(loc_list : Location*, tile_list : felt*, n_steps, dict : DictAccess*) -> (dict : DictAccess*)
# finalize_state(dict : DictAccess*, idx) -> (dict : DictAccess*)
%builtins output range_check

from starkware.cairo.common.registers import get_fp_and_pc
from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.squash_dict import squash_dict

struct Location:
    member row : felt
    member col : felt
end

func verify_valid_location(loc : Location*):
    tempvar row = loc.row
    assert row * (row - 1) * (row - 2) * (row - 3) = 0

    tempvar col = loc.col
    assert col * (col - 1) * (col - 2) * (col - 3) = 0
    return()
end

func verify_adjacent_location(loc0 : Location*, loc1 : Location*):
    # (0, 1) is adjacent to (0, 2) and (1, 1), but is not adjacent to (1, 2)
    alloc_locals
    local row_diff = loc0.row - loc1.row
    local col_diff = loc0.col - loc1.col

    if row_diff == 0:
        assert col_diff * col_diff = 1
        return()
    else:
        assert col_diff = 0
        assert row_diff * row_diff = 1
        return()
    end    
end

func verify_location_list(loc_list : Location*, n_steps : felt):
    verify_valid_location(loc = loc_list)

    if n_steps == 0:
        assert loc_list.row = 3
        assert loc_list.col = 3
        return()
    end

    verify_adjacent_location(loc0 = loc_list, loc1 = loc_list + Location.SIZE)

    verify_location_list(loc_list = loc_list + Location.SIZE, n_steps = n_steps - 1)
    return()
end

func build_dict(loc_list : Location*, tile_list : felt*, n_steps, dict : DictAccess*) -> (dict : DictAccess*):
    # For every element in the tile_list, we will define key, prev_value, new_value.
    # The location at loc_list + Location.SIZE will be prev.value and at the loc_list will be the new_value.
    if n_steps == 0:
        return (dict = dict)
    end

    assert dict.key = [tile_list] # can't we just say tile_list, try it.

    let next_loc : Location* = loc_list + Location.SIZE

    assert dict.prev_value = 4 * next_loc.row + next_loc.col
    assert dict.new_value = 4 * loc_list.row + loc_list.col

    return build_dict(
    loc_list = next_loc,
    tile_list = tile_list + 1,
    n_steps = n_steps - 1,
    dict = dict + DictAccess.SIZE) # tile recursion, we will reformat
end

func finalize_state(dict : DictAccess*, idx) -> (dict : DictAccess*):
    if idx == 0:
        return(dict = dict)
    end

    assert dict.key = idx
    assert dict.prev_value = idx - 1
    assert dict.new_value = idx - 1

    return finalize_state(dict = dict + DictAccess.SIZE, idx = idx - 1)
end

func output_initial_state{output_ptr : felt*}(squashed_dict : DictAccess*, n):
    if n == 0:
        return()
    end

    serialize_word(squashed_dict.prev_value)

    return output_initial_state(squashed_dict = squashed_dict + DictAccess.SIZE, n = n - 1)
end

func check_solution{output_ptr : felt*, range_check_ptr}(loc_list : Location*, tile_list : felt*, n_steps):
    alloc_locals

    verify_location_list(loc_list, n_steps)

    let(local dict_start : DictAccess*) = alloc()
    let(local squashed_dict: DictAccess*) = alloc()

    let (dict_end) = build_dict(
        loc_list = loc_list, 
        tile_list = tile_list, 
        n_steps = n_steps, 
        dict = dict_start)

    let (dict_end) = finalize_state(dict = dict_end, idx = 15)

    let (squashed_dict_end) = squash_dict(
        dict_accesses = dict_start, 
        dict_accesses_end = dict_end, 
        squashed_dict = squashed_dict)
    
    local range_check_ptr = range_check_ptr # Why do we use it???

    assert squashed_dict_end - squashed_dict = 15 * DictAccess.SIZE # Why do we need it to verify???

    serialize_word(4 * loc_list.row + loc_list.col) # Initial location of the empty tile.
    serialize_word(n_steps)

    return()
end

func main{output_ptr : felt*, range_check_ptr}():
    alloc_locals

    local loc_list : Location*
    local tile_list : felt*
    local n_steps

    %{
        locations = program_input['loc_list']
        tiles = program_input['tile_list']

        ids.loc_list = loc_list = segments.add()
        for i, val in enumerate(locations):
            memory[loc_list + i] = val

        ids.tile_list = tile_list = segments.add()
        for i, val in enumerate(tiles):
            memory[tile_list + i] = val

        ids.n_steps = len(tiles)

        assert len(locations) == 2*(len(tiles) + 1)
    %}

    check_solution(
        loc_list = loc_list,
        tile_list = tile_list,
        n_steps = n_steps)
    return()
end