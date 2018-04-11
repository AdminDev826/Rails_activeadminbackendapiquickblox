faqs = @faqs

json.faqs faqs do |faq|
  json.id faq.id
  json.question faq.question
  json.answer faq.answer
end