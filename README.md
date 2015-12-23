[![Platform](http://img.shields.io/badge/platform-ios-blue.svg?style=flat
)](https://developer.apple.com/iphone/index.action)
[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat
)](https://developer.apple.com/swift)
[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat
)](http://mit-license.org)

# ios-universal-widget
> Simple universal widget for iOS (iOS more 8.0) based json format

## How to install
```pod install```
and ```run universalwidget.xcworkspace```

## How to use
1. Add URL to json page through tab "Добавить JSON" (tap button "+")
2. For viewing the results, select the cell
3. For adding the widget tap button "Виджеты" and check on desired json file
4. Add widget on notification bar (maximum - 4 widget)

## Received json format
```{  
   "title":"Title",
   "type":"list",
   "date":"23.12.2015 14:06",
   "data":[  
   		{  
         "name":"Подзаголовок 1:",
         "value":""
      },
      {  
         "name":"Данные 1",
         "value":"Значение 1"
      },
      {  
         "name":"Данные 2",
         "value":"Значение 2"
      }
   ]
}```


## Licence
MIT ©
