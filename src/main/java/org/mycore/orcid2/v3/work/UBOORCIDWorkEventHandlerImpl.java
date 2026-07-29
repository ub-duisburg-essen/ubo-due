package org.mycore.orcid2.v3.work;

import java.util.List;
import java.util.Set;

import org.mycore.common.content.MCRJDOMContent;
import org.mycore.orcid2.client.MCRORCIDCredential;
import org.mycore.orcid2.metadata.MCRORCIDPutCodeInfo;
import org.mycore.orcid2.util.MCRIdentifier;
import org.mycore.orcid2.v3.transformer.MCRORCIDWorkTransformerHelper;
import org.mycore.orcid2.work.MCRORCIDWorkEventHandler;
import org.orcid.jaxb.model.v3.release.record.Work;

/**
 * Overrides {@link MCRORCIDWorkEventHandlerImpl} to allow for repair.
 */
public class UBOORCIDWorkEventHandlerImpl extends MCRORCIDWorkEventHandler<Work> {

    @Override
    protected void removeWork(MCRORCIDPutCodeInfo workInfo, String orcid, MCRORCIDCredential credential) {
        MCRORCIDWorkService.doDeleteWork(workInfo, orcid, credential);
    }

    @Override
    protected void createWork(Work work, MCRORCIDPutCodeInfo workInfo, String orcid, MCRORCIDCredential credential) {
        MCRORCIDWorkService.doCreateWork(work, workInfo, orcid, credential);
    }

    @Override
    protected void updateWork(long putCode, Work work, String orcid, MCRORCIDCredential credential) {
        MCRORCIDWorkService.doUpdateWork(putCode, work, orcid, credential);
    }

    @Override
    protected void updateWorkInfo(Set<MCRIdentifier> identifiers, MCRORCIDPutCodeInfo workInfo, String orcid,
        MCRORCIDCredential credential) {
        MCRORCIDWorkService.doUpdateWorkInfo(identifiers, workInfo, orcid, credential);
    }

    @Override
    protected void updateWorkInfo(Set<MCRIdentifier> identifiers, MCRORCIDPutCodeInfo workInfo, String orcid) {
        MCRORCIDWorkService.doUpdateWorkInfo(identifiers, workInfo, orcid);
    }

    @Override
    protected Set<MCRIdentifier> listTrustedIdentifiers(Work work) {
        return MCRORCIDWorkUtils.listTrustedIdentifiers(work);
    }

    @Override
    protected Set<String> findMatchingORCIDs(Set<MCRIdentifier> identifiers) {
        return MCRORCIDWorkService.findMatchingORCIDs(identifiers);
    }

    @Override
    protected Work transformObject(MCRJDOMContent object) {
        return MCRORCIDWorkTransformerHelper.transformContent(object);
    }

    @Override
    protected List<String> listRelatedOrcidIdentifiers(Work work) {
        if (work.getWorkContributors() != null && work.getWorkContributors().getContributor() != null) {
            return work.getWorkContributors().getContributor().stream().filter(c -> c.getContributorOrcid() != null)
                .filter(c -> c.getContributorAttributes() != null)
                .filter(c -> c.getContributorAttributes().getContributorRole() != null)
                .map(c -> c.getContributorOrcid().getPath()).toList();
        }
        return List.of();
    }
}
