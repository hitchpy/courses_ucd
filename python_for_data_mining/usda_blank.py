'''
A simple client for USDA statistics
    http://quickstats.nass.usda.gov/api

Found the data set in the data.gov catalog:
    http://catalog.data.gov/dataset/quick-stats-agricultural-database-api

Fun fact: This actually queries a database with 31 million records
'''

import requests


# Posting your keys online for anyone to find and use is a BAD IDEA!

# You'll need to change this to the key from the email.
# Only use this technique if this script will remain private, ie. stored
# just on your local computer.
usda_key = 'api key'
# If you save this publicly to Github then it's better to keep your key in
# a separate private plain text file called 'usda_key.txt' which is NOT
# added / committed to the repository.
try:
    with open('usda_key.txt') as f:
        usda_key = f.read().rstrip()
except FileNotFoundError:
    pass



def get_param_values(param, key=usda_key):
    '''
    Returns the possible values for a single parameter 'param'

    >>> get_param_values('sector_desc')[:3]
    ['ANIMALS & PRODUCTS', 'CROPS', 'DEMOGRAPHICS']

    '''
    # Your task- fill this in
    res = requests.get('http://quickstats.nass.usda.gov/api/get_param_values/',
            params={'key' : key, 'param' : param})
    return(res.json()[param])


def query(parameters, key=usda_key):
    '''
    Returns the JSON response from the USDA agricultural database

    'parameters' is a dictionary of parameters that can be referenced here:
        http://quickstats.nass.usda.gov/api

    Example: Return all the records around cattle in Tehama County

    >>> cowparams = {'commodity_desc': 'CATTLE',
                     'state_name': 'CALIFORNIA',
                     'county_name': 'TEHAMA'}
    >>> tehamacow = query(cowparams)

    '''
    parameters['key'] = key
    parameters['format'] = 'json'
    # Your task- fill this in
    res = requests.get('http://quickstats.nass.usda.gov/api/api_GET/',
            params = parameters)
    return(res.json()['data'])


if __name__ == '__main__':
    # A few examples of usage

    # Possible values for 'commodity_desc'
    commodity_desc = get_param_values('commodity_desc')
    # Expect:
    # ['AG LAND', 'AG SERVICES', 'AG SERVICES & RENT',
    # 'ALMONDS', ...

    # Value of rice crops in Yolo (Davis) county since 2005
    riceparams = {'sector_desc': 'CROPS',
                  'commodity_desc': 'RICE',
                  'state_name': 'CALIFORNIA',
                  'county_name': 'YOLO',
                  'year__GE': '2005',
                  'unit_desc': '$',
                  }

    yolorice = query(riceparams)

    # Try using a dictionary comprehension to filter
    yearvalue = {x['year']: x['Value'] for x in yolorice}

    tobacco = {'sector_desc': 'CROPS', 
                'domain_desc': 'TOTAL',
                'commodity_desc': 'TOBACCO',
                'year': '2012',
                'agg_level_desc': 'STATE',
                'source_desc': 'CENSUS',
                'unit_desc': '$'}
    b = query(tobacco)
    res = {x['state_name']:x['Value'] for x in b}
    aa = {x:int(res[x].replace(',', '')) if res[x].strip() != '(D)' else 0 for x in res.keys()}
    sorted(aa.items(), key = lambda x:x[1], reverse = True)[:10]
    # Expect:
    # {'2007': '26,697,000', '2012': '51,148,000'}
