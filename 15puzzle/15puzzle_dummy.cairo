# It's an example from the cairo-lang, Hello, Cairo! part
# What I will do is to write three functions and a Struct
# The Struct will be a location Struct
# functions will be verify_valid_location, verify_adjacent_location, and verify_location_list
from starkware.cairo.common.registers import get_fp_and_pc

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
    # (0, 1) is adj to (0, 2), (1,1) but not adj to (1, 2)
    alloc_locals
    local row_diff = loc0.row - loc1.row
    local col_diff = loc0.col - loc1.col

    if row_diff == 0:
        assert (col_diff) * (col_diff) = 1
        return()

    else:
        assert (row_diff) * (row_diff) = 1
        assert col_diff = 0
    return()
    end
end

func verify_location_list(loc_list : Location*, n_steps : felt):
    alloc_locals
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

func main():
    alloc_locals
    local loc_tuple : (Location, Location, Location, Location, Location) = ( 
    Location(row = 0, col= 2),
    Location(row = 1, col = 2),
    Location(row = 1, col = 3),
    Location(row = 2, col = 3),
    Location(row = 3, col = 3))

    let (__fp__, _) = get_fp_and_pc()

    verify_location_list(loc_list = cast(&loc_tuple, Location*), n_steps = 4)
    return()
end