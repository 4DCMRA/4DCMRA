function output = nmlz(input)
output = (input-min(input(:)))/(max(input(:))-min(input(:)));