//
//  Information+Addition.m
//  WeTongji
//
//  Created by tang zhixiong on 12-11-9.
//
//

#import "Information+Addition.h"
#import "NSString+Addition.h"
#import <WeTongjiSDK/WetongjiSDK.h>

@implementation Information (Addition)

+(Information *) insertAnInformation:(NSDictionary *) infoDict inCategory:(NSString *) category inManagedObjectContext:(NSManagedObjectContext *) context
{
    NSString * informationId = [NSString stringWithFormat:@"%@", [infoDict objectForKey:@"Id"]];
    if ( !informationId || [informationId isEqualToString:@""]) return nil;
    Information * information = [Information getInformationWithId:informationId inCategory:category inManagedObjectContext:context];
    if ( !information )
    {
        information = [NSEntityDescription insertNewObjectForEntityForName:@"Information" inManagedObjectContext:context];
    }
    if ( [information.canFavorite boolValue] || !information.canFavorite )
        information.canFavorite = [NSNumber numberWithInt:[[infoDict objectForKey:@"CanFavorite"] intValue]];
    if ( [information.canLike boolValue] || !information.canLike )
        information.canLike = [NSNumber numberWithInt:[[infoDict objectForKey:@"CanLike"] intValue]];
    information.category = [NSString stringWithFormat:@"%@",category];
    information.contact = [NSString stringWithFormat:@"%@",[infoDict objectForKey:@"Contact"]];
    information.context = [NSString stringWithFormat:@"%@",[infoDict objectForKey:@"Context"]];
    information.createdAt = [[NSString stringWithFormat:@"%@",[infoDict objectForKey:@"CreatedAt"]] convertToDate];
    information.favorite = [NSNumber numberWithInt:[[infoDict objectForKey:@"Favorite"] intValue]];
    information.informationId = [NSString stringWithFormat:@"%@",[infoDict objectForKey:@"Id"]];
    information.image = [NSString stringWithFormat:@"%@",[infoDict objectForKey:@"Image"]];
    information.images = [NSString stringWithFormat:@"%@",[[infoDict objectForKey:@"Images"] JSONRepresentation]];
    NSLog(@"%@",[infoDict objectForKey:@"Images"]);
    information.like = [NSNumber numberWithInt:[[infoDict objectForKey:@"Like"] intValue]];
    information.location = [NSString stringWithFormat:@"%@",[infoDict objectForKey:@"Location"]];
    information.title = [NSString stringWithFormat:@"%@",[infoDict objectForKey:@"TicketService"]];
    information.organizer = [NSString stringWithFormat:@"%@",[infoDict objectForKey:@"Organizer"]];
    information.organizerAvatar = [NSString stringWithFormat:@"%@",[infoDict objectForKey:@"OrganizerAvatar"]];
    information.read = [NSNumber numberWithInt:[[infoDict objectForKey:@"Read"] intValue]];;
    information.source = [NSString stringWithFormat:@"%@",[infoDict objectForKey:@"Source"]];
    information.summary = [NSString stringWithFormat:@"%@",[infoDict objectForKey:@"Summary"]];
    information.ticketService = [NSString stringWithFormat:@"%@",[infoDict objectForKey:@"TicketService"]];
    information.title = [NSString stringWithFormat:@"%@",[infoDict objectForKey:@"Title"]];
    if ( [information.category isEqualToString:GetInformationTypeAround] ) {
        information.collectionSummary = information.summary;
    } else if ( [information.category isEqualToString:GetInformationTypeClubNews] ) {
        information.collectionSummary = information.organizer;
    } else if ( [information.category isEqualToString:GetInformationTypeForStaff] ) {
        information.collectionSummary = information.summary;
    } else if ( [information.category isEqualToString:GetInformationTypeSchoolNews] ) {
        information.collectionSummary = information.summary;
    }
    if ( [information.location isEqualToString:@""] ) information.location = [NSString stringWithFormat:@"%@",[NSNull null] ];
    if ( [information.contact isEqualToString:@""] ) information.contact = [NSString stringWithFormat:@"%@",[NSNull null] ];;
    if ( [information.ticketService isEqualToString:@""] )
        information.ticketService = [NSString stringWithFormat:@"%@",[NSNull null] ];;
    information.collectionTitle = information.title;
    information.collectionSource = @"校园资讯";
    return information;
}

-(NSNumber *) can_favorite
{
    return self.canFavorite;
}

+(NSArray *) getAllInformationWithCategory:(NSString *) category inManagedObjectContext:(NSManagedObjectContext *) context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Information" inManagedObjectContext:context]];
    if ( category ) 
        [request setPredicate:[NSPredicate predicateWithFormat:@"category == %@", category]];
    NSArray *result = [context executeFetchRequest:request error:NULL];
    return result;
}

+(Information *) getInformationWithId:(NSString*) informaionId inCategory:(NSString *) category inManagedObjectContext:(NSManagedObjectContext *) context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:[NSEntityDescription entityForName:@"Information" inManagedObjectContext:context]];
    NSPredicate *informationIdPredicate = [NSPredicate predicateWithFormat:@"informationId == %@", informaionId];
    NSPredicate *informationCategoryPredicate = [NSPredicate predicateWithFormat:@"category == %@", category];
    [request setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:informationIdPredicate, informationCategoryPredicate, nil]]];
    Information *result = [[context executeFetchRequest:request error:NULL] lastObject];
    
    return result;
}

+(void) clearDataInManagedObjectContext:(NSManagedObjectContext *) context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Information" inManagedObjectContext:context]];
    NSArray *items = [context executeFetchRequest:fetchRequest error:NULL];
    for (NSManagedObject *managedObject in items)
        [context deleteObject:managedObject];
}

@end
