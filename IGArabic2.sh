#!/bin/bash

input_file="IGArabic.json"
output_file="Tweak.xm"

> "$output_file"

cat <<EOF >> "$output_file"
#import <UIKit/UIKit.h>

NSDictionary *translationDictionary = @{
EOF

jq -r 'to_entries[] | "    @\"\(.key)\" : @\"\(.value)\","' "$input_file" >> "$output_file"

cat <<EOF >> "$output_file"
};

NSString *translateText(NSString *text) {
    return translationDictionary[text] ?: text;
}

%hook UILabel
-(void)setText:(id)arg1 {
    %orig(translateText(arg1));
}
%end

%hook IGCoreTextView
-(void)setText:(id)arg1 {
    %orig(translateText(arg1));
}
%end

%hook UITextView
-(void)setText:(id)arg1 {
    %orig(translateText(arg1));
}
%end

%hook UITextField
-(void)setText:(id)arg1 {
    %orig(translateText(arg1));
}
%end

%hook UIButton
-(void)setTitle:(id)arg1 forState:(UIControlState)state {
    %orig(translateText(arg1), state);
}
%end
EOF