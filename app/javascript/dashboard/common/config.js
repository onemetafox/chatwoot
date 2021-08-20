export const ADMIN_FIELD_AS = {
  'Short Answer': 'string' , 
  'Long Answer': 'text', 
  'Email, Address': 'email', 
  'Url': 'url', 
  'Phone Number': 'tel',
  'Select List': 'select', 
  'Radio Buttons': 'radio_button', 
  'CheckBox List': 'check_boxes', 'Checkbox': 'boolean', 
  'Date': 'date', 'Date & Time':  'datetime', 
  'Number(Decimal)': 'decimal', 'Number(Integer)': 'integer', 'Number(Floating Point)': 'float', 
  'Date Pair': 'date_pair', 'Date & Time Pair': 'datetime_pair'
}
export const AF_FORM_HIDDEN = {
  radio_button: ['maxlength', 'minlength', 'placeholde'], 
  date: ['maxlength', 'minlength', 'placeholde'], 
  datetime: ['maxlength', 'minlength', 'placeholde'],
  decimal: ['maxlength', 'minlength', 'placeholde'], 
}