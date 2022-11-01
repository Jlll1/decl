-- {start_row, start_col, end_row, end_col}
local function does_range_contain(containing_range, contained_range)
  local is_in_range_start = containing_range[1] < contained_range[1] or
    (containing_range[1] == contained_range[1] and containing_range[2] < containing_range[2])
  local is_in_range_end = containing_range[3] > contained_range[1] or
    (containing_range[3] == contained_range[3] and containing_range[4] > containing_range[4])
  return is_in_range_start and is_in_range_end
end
