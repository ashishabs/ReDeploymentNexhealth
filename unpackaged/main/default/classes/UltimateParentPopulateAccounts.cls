/**********************************************************
Class: UltimateParentPopulateAccounts 
LastModifiedBy: Cloud connex 05/02/2023
Description: populate the HierarchyLevel and Total Child Locations on Accounts Hiearchy
TestClass : BatchUltimateParentPopulateAccountsTest
***********************************************************/
public class UltimateParentPopulateAccounts {
    
    private List<Account> theAccList;
    
    public UltimateParentPopulateAccounts(List<Account> theAccList) {
        this.theAccList = theAccList;
    }
    
    public void execute() { 
        
        Set<Id> allAccountIds = new Set<Id>();
        allAccountIds.addAll(new Map<Id,Account>(theAccList).keySet());
        List<AccountHierarchyTree> hierarchies = new List<AccountHierarchyTree>();
        buildTreesFromList(hierarchies,theAccList);
        
        Set<Id> parentIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for(AccountHierarchyTree tree: hierarchies){
            ParentIds.addAll(tree.getParentIds());
            accountIds.addAll(tree.getAccountIds());
        }
        
        List<Account> newNodes = parentsAndChildrenQuery(parentIds, accountIds, allAccountIds);
        while(!newNodes.isEmpty()){
            allAccountIds.addAll(new Map<Id,Account>(newNodes).keySet());
            buildTreesFromList(hierarchies,newNodes);
            
            // merge trees
            hierarchies = mergeTrees(hierarchies);
            
            // Get new accounts
            for(AccountHierarchyTree tree: hierarchies){
                ParentIds.addAll(tree.getParentIds());
                accountIds.addAll(tree.getAccountIds());
            } 
            newNodes = parentsAndChildrenQuery(parentIds, accountIds, allAccountIds);
        }
        
        List<Account> accountsToUpdate = new List<Account>();
        // Traverse them to update the following:
        for(AccountHierarchyTree hierarchy: hierarchies){
            // Depth
            hierarchy.populateHierarchyLevel();
            // Number of Children that are Type = Practice Location
            hierarchy.populateTotalChildLocations();
            // Update the Accounts with the new values
            List<Account> hierarchyAccounts = hierarchy.getAccounts();
            for(Account acct: hierarchyAccounts) accountsToUpdate.add(new Account(Id=acct.id,Hierarchy_Level__c=acct.Hierarchy_Level__c,Total_Child_Locations__c=acct.Total_Child_Locations__c));
        }
        
        update accountsToUpdate;
    }
    
    public static void buildTreesFromList(List<AccountHierarchyTree> trees, List<Account> accts){
        
        for(Account acct: accts){
            
            Boolean added = false;
            for(AccountHierarchyTree tree: trees){
                if(tree.isAddable(acct)){
                    tree.addNode(acct);
                    added = true;
                    break;
                } 
            }
            if(!added) trees.add(new AccountHierarchyTree(acct));
        }
    }
    
    public static List<AccountHierarchyTree> mergeTrees(List<AccountHierarchyTree> trees){
        List<AccountHierarchyTree> newlist = new List<AccountHierarchyTree>();
        newlist.addAll(trees);
        Boolean mergeable = true;
        while(mergeable){
            mergeable = false;
            // check merge
            for(Integer treeItr=0;treeItr<newlist.size()-1;treeItr++){
                if(newlist[treeItr+1].getParentIds().contains(newlist[treeItr].getRoot().ParentId) || newlist[treeItr].getParentIds().contains(newlist[treeItr+1].getRoot().ParentId)){
                    mergeable = true;
                    newlist[treeItr+1].mergeTrees(newlist[treeItr]);
                    newlist.remove(treeItr);
                } 
            }
        }
        
        return newlist;
    } 
    
    public List<Account> parentsAndChildrenQuery(Set<Id> parentIds, Set<Id> accountIds, Set<Id> exclusionIds){
        List<Account> otherAccounts = [Select id, Name,Type, ParentId, Ultimate_Parent__c, Became_a_Customer_Date__c From Account Where (Id IN :parentIds OR ParentId IN :accountIds) AND ID NOT IN :exclusionIds];
        return otherAccounts;
    }
    
}