[data_matrix,id_list]=new_transmit_and_get('localhost',3002,3001);
%imagesc(data_matrix)
size(data_matrix)
imagesc(reshape(data_matrix,1024,1392));