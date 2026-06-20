import IUser from "@/resources/user/user.interface";
import IContact from "@/resources/common/common.interface";
import userModel from "@/resources/user/user.model";

class CommonService {

    private userModel = userModel

    public async validateContacts(
        contacts: IContact[],
        user: IUser
    ): Promise<any | Error> {
        try {

            const normalizedContacts = contacts.map(contact => ({
                ...contact,
                normalizedMobile: contact.mobile.slice(-9)
            }));

            const mobileSuffixes = normalizedContacts.map(c => c.normalizedMobile);
            let allUsers:IUser[] = []
            for (let i = 0; i < mobileSuffixes.length; i += 1000) {
                const batch = mobileSuffixes.slice(i, i + 1000);
                const appUsers = await this.userModel.find({
                    mobile: {
                        $regex: batch.map(suffix => `${suffix}$`).join('|'),
                        $options: 'i'
                    }
                }).select('_id avatar displayName code mobile') as IUser[]; 
                allUsers.push(...appUsers)
            }            
            
            const contactsMap: { [key: string]: any } = {};
            allUsers.forEach(appUser => {
                contactsMap[appUser.mobile.slice(-9)] = appUser;
            });

            return normalizedContacts.map(contact => {
                const matchedUser = contactsMap[contact.normalizedMobile];
                return matchedUser
                    ? {
                        ...contact,
                        id: matchedUser._id,
                        avatar: matchedUser.avatar,
                        displayName: matchedUser.displayName
                    }
                    : contact;
            })
        }catch (error: any) {
            throw new Error(error.message)
        }
    }
}
export default CommonService