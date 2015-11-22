# The following is a challenge in Ruby which I thought would be quite easy, but... isn't. 

# So the issue is user #1 (identified by his international phone number) invites his friend user #2 by SMS and tells us he invited his friend. Because the invititation is by SMS, the number might be local and might be international. Your challenge, should you choose to accept it, is to convert user #2's number to an international format, as follows:

# If user #2's number is already international, save it as is. If not, take user #1's country code (as parsed from his international number) and add that country code to user #2's number. (Take note adding a country-code is non-trivial; e.g. in Israel you remove the first '0' to do this properly, while in the US you don't.)

# You may use any external (Ruby) libs or gems for this. 



to_international(src, friend) == friend_in_international_format

#Proposed structure of solution:
def to_international(international_number_one, number_two)
  if is_international?(number_two)
    return number_two 
  else 
    country = get_country(international_number_one)
    international_number_two = make_international(number_two, country)
    return international_number_two
  end 
end

# For example:

to_international('972522934321', '0547805206')   == '972547805206'   #friend in same country, local number (IL)
to_international('12125009999', '7348001234')    == '17348001234'     #friend in same country, local number (USA)
to_international('972522934321', '972547805206') == '972547805206' #friend in same country, international number.
to_international('972522934321', '17348001234') == '17348001234' #friend in other country, international number.

# Good luck!

### Solution (taken from here: https://github.com/SellaRafaeli/pickeez/blob/master/bl/phones.rb)

module Phones
  extend self

  def get_phone_country_code(international_number)
    Phonelib.parse(international_number).country
  end

  def international_to_local(international_number)
    Phonelib.parse(international_number).national.tr('-','')
  end

  def local_to_international(local_number,country_code)
    PhonyRails.normalize_number(local_number, :country_code => country_code)
  end

  def is_international_phone?(phone)
    Phonelib.valid?(phone)
  end

  def sanitize_phone(international_number)
    Phonelib.parse(international_number).sanitized
  end

  # this method turns 'new_user_number' into an international phone. 
  # If it's already an international phone, return it.
  # Otherwise (it's a local phone), assume it's from the same country as 
  # the first phone, and transform it into the international format of that country.
  # Thus, if user1 (for whom we have an international phone number) invites user2 via 
  # an either local or international number, we can create user2's number and now we (hopefully) 
  # have user2's international number.   
  def to_international(new_number, international_number_hint)
    if is_international_phone?(new_number)
      sanitize_phone(new_number) 
    else   
      country_code = get_phone_country_code(international_number_hint)
      international_new_number = local_to_international(new_number, country_code)
      sanitize_phone(international_new_number)
    end
  end
end

# The default inviter is a random US number, so if user with no phones invites
# some number) we will assume it is a US number.
# (Note not using default param because passing in nil overrides a default param.)
def force_international(invited_num, inviter_num)
  Phones.to_international(invited_num, inviter_num || '12125551234')
end

def test_force_international
  puts force_international('0547805206', '972522934321')   == '972547805206'   #friend in same country, local number (IL)
  puts force_international( '7348001234', '12125009999')    == '17348001234'     #friend in same country, local number (USA)
  puts force_international('972547805206', '972522934321') == '972547805206' #friend in same country, international number.
  puts force_international('17348001234', '972522934321') == '17348001234' #friend in other country, international number.
  puts force_international('7348001234') == '17348001234' #no number, assume hint is USA
end