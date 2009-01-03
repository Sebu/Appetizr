

def get_lockstate(user)
  puts CONFIG['pw_check_file']
  system("#{CONFIG['pw_check_file']} #{user}")
  case $?
    when 0:   false
    when 512: true
    else      true
  end
end
