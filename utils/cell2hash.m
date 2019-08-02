function hash = cell2hash(data)
  % hashes a cell array of numerical matrices

  A = [];
  for ii = 1:numel(data)
    A = [A; corelib.vectorise(data{ii})];
  end

  hash = hashlib.md5hash(A);

end % function
