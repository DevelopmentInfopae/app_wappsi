String removeHtmlElements(String html){
  final temp =  html.replaceAll('<p>', '').replaceAll('</p>', '');
  return temp;
}
String htmlFormating(String html){
  final temp =  html.replaceAll('&lt;p&gt;', '<p> ').replaceAll('&lt;&sol;p&gt;', '</p>');
  return temp;
}