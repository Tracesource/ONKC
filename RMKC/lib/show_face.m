function Y = show_face(X, im_height, im_width, numPerLine, ShowLine)
Y = zeros(im_height*ShowLine,im_width*numPerLine); 
for i=0:ShowLine-1 
  	for j=0:numPerLine-1 
    	 Y(i*im_height+1:(i+1)*im_height,j*im_width+1:(j+1)*im_width) = reshape(X(i*numPerLine+j+1,:),[im_height,im_width]); 
  	end 
end
if nargout == 0
    imshow(Y, [min(min(Y)), max(max(Y))]);
end 
end