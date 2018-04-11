// var app = window.app = {};
// app.TaskAutocomplete = function() {
//   this._input = $('#tasks-search-txt');
//   this._initAutocomplete();
// };

// app.TaskAutocomplete.prototype = {

// };

// _initAutocomplete: function() {
//   this._input
//     .autocomplete({
//       source: '/tasks',
//       appendTo: '#tasks-search-results',
//       select: $.proxy(this._select, this)
//     })
//     .autocomplete('instance')._renderItem = $.proxy(this._render, this);
// }

// _select: function(e, ui) {
//   this._input.val(ui.item.title + ' - ' + ui.item.first_name);
//   return false;
// }