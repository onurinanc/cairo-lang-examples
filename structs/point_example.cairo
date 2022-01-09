%builtins output

# Import the serialize_word() function.
from starkware.cairo.common.serialize import serialize_word

struct Point:
    member row : felt
    member col : felt
end 

func verify_valid_point(point: Point):
    tempvar row = point.row
    assert row * (row-1) * (row-2) * (row-3) = 0
    
    tempvar col = point.col
    assert col * (col-1) * (col-2) * (col-3) = 0
    return()
end

func main{output_ptr : felt*}():  
    alloc_locals
    
    local a : Point = Point(row = 0, col = 2)
    local row_1 = a.row
    local col_1 = a.col
    
    local b : Point = Point(row = 3, col = 4)
    # why can not we assign let instead of local?
    verify_valid_point(a)
    verify_valid_point(b) # this will throw error
    
    serialize_word(row_1)
    serialize_word(col_1)
    return()
end
