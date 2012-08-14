define :splunk_input do
  name = params.delete(:name)
  node.set[:splunk][:inputs][name] = params
end
