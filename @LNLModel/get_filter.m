function filter = get_filter(filter_name)

  if ~exist('filter_name', 'var')
    filter_name = 'hardcastle';
  end

  switch filter_name
  case 'hardcastle'
    filter = gaussmf(-4:4, [2, 0]);
    filter = filter / sum(filter);
  otherwise
    error('unknown filter name')
  end
