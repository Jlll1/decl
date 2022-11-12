local M = {}

-- {start_row, start_col, end_row, end_col}
function M.does_range_contain(containing_range, contained_range)
  local is_in_range_start = containing_range[1] < contained_range[1] or
    (containing_range[1] == contained_range[1] and containing_range[2] < containing_range[2])
  local is_in_range_end = containing_range[3] > contained_range[1] or
    (containing_range[3] == contained_range[3] and containing_range[4] > containing_range[4])
  return is_in_range_start and is_in_range_end
end

function M.does_node_contain(containing_node, contained_node)
  local containing_start_row, containing_start_col, containing_end_row, containing_end_col = containing_node:range()
  local contained_start_row, contained_start_col, contained_end_row, contained_end_col = contained_node:range()
  return utils.does_range_contain(
    {containing_start_row, containing_start_col, containing_end_row, containing_end_col},
    {contained_start_row, contained_start_col, contained_end_row, contained_end_col})
end

return M
