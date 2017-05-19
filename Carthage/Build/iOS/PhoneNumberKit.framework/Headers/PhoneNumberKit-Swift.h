// Generated by Apple Swift version 3.1 (swiftlang-802.0.51 clang-802.0.41)
#pragma clang diagnostic push

#if defined(__has_include) && __has_include(<swift/objc-prologue.h>)
# include <swift/objc-prologue.h>
#endif

#pragma clang diagnostic ignored "-Wauto-import"
#include <objc/NSObject.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#if !defined(SWIFT_TYPEDEFS)
# define SWIFT_TYPEDEFS 1
# if defined(__has_include) && __has_include(<uchar.h>)
#  include <uchar.h>
# elif !defined(__cplusplus) || __cplusplus < 201103L
typedef uint_least16_t char16_t;
typedef uint_least32_t char32_t;
# endif
typedef float swift_float2  __attribute__((__ext_vector_type__(2)));
typedef float swift_float3  __attribute__((__ext_vector_type__(3)));
typedef float swift_float4  __attribute__((__ext_vector_type__(4)));
typedef double swift_double2  __attribute__((__ext_vector_type__(2)));
typedef double swift_double3  __attribute__((__ext_vector_type__(3)));
typedef double swift_double4  __attribute__((__ext_vector_type__(4)));
typedef int swift_int2  __attribute__((__ext_vector_type__(2)));
typedef int swift_int3  __attribute__((__ext_vector_type__(3)));
typedef int swift_int4  __attribute__((__ext_vector_type__(4)));
typedef unsigned int swift_uint2  __attribute__((__ext_vector_type__(2)));
typedef unsigned int swift_uint3  __attribute__((__ext_vector_type__(3)));
typedef unsigned int swift_uint4  __attribute__((__ext_vector_type__(4)));
#endif

#if !defined(SWIFT_PASTE)
# define SWIFT_PASTE_HELPER(x, y) x##y
# define SWIFT_PASTE(x, y) SWIFT_PASTE_HELPER(x, y)
#endif
#if !defined(SWIFT_METATYPE)
# define SWIFT_METATYPE(X) Class
#endif
#if !defined(SWIFT_CLASS_PROPERTY)
# if __has_feature(objc_class_property)
#  define SWIFT_CLASS_PROPERTY(...) __VA_ARGS__
# else
#  define SWIFT_CLASS_PROPERTY(...)
# endif
#endif

#if defined(__has_attribute) && __has_attribute(objc_runtime_name)
# define SWIFT_RUNTIME_NAME(X) __attribute__((objc_runtime_name(X)))
#else
# define SWIFT_RUNTIME_NAME(X)
#endif
#if defined(__has_attribute) && __has_attribute(swift_name)
# define SWIFT_COMPILE_NAME(X) __attribute__((swift_name(X)))
#else
# define SWIFT_COMPILE_NAME(X)
#endif
#if defined(__has_attribute) && __has_attribute(objc_method_family)
# define SWIFT_METHOD_FAMILY(X) __attribute__((objc_method_family(X)))
#else
# define SWIFT_METHOD_FAMILY(X)
#endif
#if defined(__has_attribute) && __has_attribute(noescape)
# define SWIFT_NOESCAPE __attribute__((noescape))
#else
# define SWIFT_NOESCAPE
#endif
#if defined(__has_attribute) && __has_attribute(warn_unused_result)
# define SWIFT_WARN_UNUSED_RESULT __attribute__((warn_unused_result))
#else
# define SWIFT_WARN_UNUSED_RESULT
#endif
#if !defined(SWIFT_CLASS_EXTRA)
# define SWIFT_CLASS_EXTRA
#endif
#if !defined(SWIFT_PROTOCOL_EXTRA)
# define SWIFT_PROTOCOL_EXTRA
#endif
#if !defined(SWIFT_ENUM_EXTRA)
# define SWIFT_ENUM_EXTRA
#endif
#if !defined(SWIFT_CLASS)
# if defined(__has_attribute) && __has_attribute(objc_subclassing_restricted)
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# else
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# endif
#endif

#if !defined(SWIFT_PROTOCOL)
# define SWIFT_PROTOCOL(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
# define SWIFT_PROTOCOL_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
#endif

#if !defined(SWIFT_EXTENSION)
# define SWIFT_EXTENSION(M) SWIFT_PASTE(M##_Swift_, __LINE__)
#endif

#if !defined(OBJC_DESIGNATED_INITIALIZER)
# if defined(__has_attribute) && __has_attribute(objc_designated_initializer)
#  define OBJC_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
# else
#  define OBJC_DESIGNATED_INITIALIZER
# endif
#endif
#if !defined(SWIFT_ENUM)
# define SWIFT_ENUM(_type, _name) enum _name : _type _name; enum SWIFT_ENUM_EXTRA _name : _type
# if defined(__has_feature) && __has_feature(generalized_swift_name)
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME) enum _name : _type _name SWIFT_COMPILE_NAME(SWIFT_NAME); enum SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_ENUM_EXTRA _name : _type
# else
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME) SWIFT_ENUM(_type, _name)
# endif
#endif
#if !defined(SWIFT_UNAVAILABLE)
# define SWIFT_UNAVAILABLE __attribute__((unavailable))
#endif
#if !defined(SWIFT_UNAVAILABLE_MSG)
# define SWIFT_UNAVAILABLE_MSG(msg) __attribute__((unavailable(msg)))
#endif
#if !defined(SWIFT_AVAILABILITY)
# define SWIFT_AVAILABILITY(plat, ...) __attribute__((availability(plat, __VA_ARGS__)))
#endif
#if !defined(SWIFT_DEPRECATED)
# define SWIFT_DEPRECATED __attribute__((deprecated))
#endif
#if !defined(SWIFT_DEPRECATED_MSG)
# define SWIFT_DEPRECATED_MSG(...) __attribute__((deprecated(__VA_ARGS__)))
#endif
#if defined(__has_feature) && __has_feature(modules)
@import Foundation;
@import ObjectiveC;
@import UIKit;
@import CoreGraphics;
#endif

#pragma clang diagnostic ignored "-Wproperty-attribute-mismatch"
#pragma clang diagnostic ignored "-Wduplicate-method-arg"

@interface NSRegularExpression (SWIFT_EXTENSION(PhoneNumberKit))
@end


SWIFT_CLASS("_TtC14PhoneNumberKit14PhoneNumberKit")
@interface PhoneNumberKit : NSObject
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
/// Get a list of all the countries in the metadata database
///
/// returns:
/// An array of ISO 639 compliant region codes.
- (NSArray<NSString *> * _Nonnull)allCountries SWIFT_WARN_UNUSED_RESULT;
/// Get an array of ISO 639 compliant region codes corresponding to a given country code.
/// \param countryCode international country code (e.g 44 for the UK).
///
///
/// returns:
/// optional array of ISO 639 compliant region codes.
- (NSArray<NSString *> * _Nullable)countriesWithCode:(uint64_t)countryCode SWIFT_WARN_UNUSED_RESULT;
/// Get an main ISO 639 compliant region code for a given country code.
/// \param countryCode international country code (e.g 1 for the US).
///
///
/// returns:
/// ISO 639 compliant region code string.
- (NSString * _Nullable)mainCountryForCode:(uint64_t)countryCode SWIFT_WARN_UNUSED_RESULT;
/// Get leading digits for an ISO 639 compliant region code.
/// \param country ISO 639 compliant region code.
///
///
/// returns:
/// leading digits (e.g. 876 for Jamaica).
- (NSString * _Nullable)leadingDigitsFor:(NSString * _Nonnull)country SWIFT_WARN_UNUSED_RESULT;
/// Get a user’s default region code
///
/// returns:
/// A computed value for the user’s current region - based on the iPhone’s carrier and if not available, the device region.
+ (NSString * _Nonnull)defaultRegionCode SWIFT_WARN_UNUSED_RESULT;
@end

@class NSCharacterSet;
@class NSCoder;

/// Custom text field that formats phone numbers
SWIFT_CLASS("_TtC14PhoneNumberKit20PhoneNumberTextField")
@interface PhoneNumberTextField : UITextField <UITextFieldDelegate>
@property (nonatomic, readonly, strong) PhoneNumberKit * _Nonnull phoneNumberKit;
/// Override region to set a custom region. Automatically uses the default region code.
@property (nonatomic, copy) NSString * _Nonnull defaultRegion;
@property (nonatomic) BOOL withPrefix;
@property (nonatomic) BOOL isPartialFormatterEnabled;
@property (nonatomic, readonly, strong) NSCharacterSet * _Nonnull nonNumericSet;
@property (nonatomic, strong) id <UITextFieldDelegate> _Nullable delegate;
@property (nonatomic, readonly, copy) NSString * _Nonnull currentRegion;
@property (nonatomic, readonly) BOOL isValidNumber;
/// Init with frame
/// \param frame UITextfield F
///
///
/// returns:
/// UITextfield
- (nonnull instancetype)initWithFrame:(CGRect)frame OBJC_DESIGNATED_INITIALIZER;
/// Init with coder
/// \param aDecoder decoder
///
///
/// returns:
/// UITextfield
- (nonnull instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
- (void)setup;
- (BOOL)textField:(UITextField * _Nonnull)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString * _Nonnull)string SWIFT_WARN_UNUSED_RESULT;
- (BOOL)textFieldShouldBeginEditing:(UITextField * _Nonnull)textField SWIFT_WARN_UNUSED_RESULT;
- (void)textFieldDidBeginEditing:(UITextField * _Nonnull)textField;
- (BOOL)textFieldShouldEndEditing:(UITextField * _Nonnull)textField SWIFT_WARN_UNUSED_RESULT;
- (void)textFieldDidEndEditing:(UITextField * _Nonnull)textField;
- (BOOL)textFieldShouldClear:(UITextField * _Nonnull)textField SWIFT_WARN_UNUSED_RESULT;
- (BOOL)textFieldShouldReturn:(UITextField * _Nonnull)textField SWIFT_WARN_UNUSED_RESULT;
@end

#pragma clang diagnostic pop
