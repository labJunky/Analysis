function update_scrolltext(newText,hText,hSlider)
  newText = textwrap(hText,newText);
  set(hText,'String',newText,'UserData',newText);
  nRows = numel(newText);
  if (nRows < 2),
    sliderEnable = 'off';
  else
    sliderEnable = 'on';
  end
  nRows = max(nRows-1,1);
  set(hSlider,'Enable',sliderEnable,'Max',nRows,...
      'SliderStep',[1 3]./nRows,'Value',nRows);
end