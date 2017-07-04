package org.jenkins.tools.test.hook;

import hudson.model.UpdateSite;
import org.apache.maven.scm.ScmFileSet;
import org.apache.maven.scm.ScmTag;
import org.apache.maven.scm.command.checkout.CheckOutScmResult;
import org.apache.maven.scm.manager.ScmManager;
import org.apache.maven.scm.repository.ScmRepository;
import org.jenkins.tools.test.SCMManagerFactory;
import org.jenkins.tools.test.model.PluginCompatTesterConfig;
import org.jenkins.tools.test.model.hook.PluginCompatTesterHookBeforeCheckout;

import java.io.File;
import java.util.List;
import java.util.Map;

/**
 * Utility class to ease create simple hooks for multimodule projects
 */

public abstract class AbstractMultiParentHook extends PluginCompatTesterHookBeforeCheckout {

    protected boolean firstRun = true;

    /**
     * All the plugins that are part of this repository.
     */
    public List<String> transformedPlugins() {
        return getBundledPlugins();
    }

    public Map<String, Object> action(Map<String, Object> moreInfo) throws Exception {
        PluginCompatTesterConfig config = (PluginCompatTesterConfig)moreInfo.get("config");
        UpdateSite.Plugin currentPlugin = (UpdateSite.Plugin)moreInfo.get("plugin");


        // We should not execute the hook if using localCheckoutDir
        boolean shouldExecuteHook = config.getLocalCheckoutDir() == null || !config.getLocalCheckoutDir().exists();

        if (shouldExecuteHook) {
            System.out.println("Executing Hook for " + getParentProjectName());
            // Determine if we need to run the download; only run for first identified plugin in the series
            if (firstRun) {
                System.out.println("Preparing for Multimodule checkout");

                // Checkout to the parent directory. All other processes will be on the child directory
                File parentPath = new File(config.workDirectory.getAbsolutePath() + "/" + getParentFolder());

                System.out.println("Checking out from SCM connection URL: " + getParentUrl() + " (" + getParentProjectName() + "-" + currentPlugin.version + ")");
                ScmManager scmManager = SCMManagerFactory.getInstance().createScmManager();
                ScmRepository repository = scmManager.makeScmRepository(getParentUrl());
                CheckOutScmResult result = scmManager.checkOut(repository, new ScmFileSet(parentPath), new ScmTag(getParentProjectName() + "-" + currentPlugin.version));

                if (!result.isSuccess()) {
                    // Throw an exception if there are any download errors.
                    throw new RuntimeException(result.getProviderMessage() + "||" + result.getCommandOutput());
                }
            }

            // Checkout already happened, don't run through again
            moreInfo.put("runCheckout", false);
            firstRun = false;

            // Change the "download"" directory; after download, it's simply used for reference
            File childPath = new File(config.workDirectory.getAbsolutePath() + "/" + getParentFolder() + "/" + currentPlugin.name);

            System.out.println("Child path for " + currentPlugin.getDisplayName() + " " + childPath);
            moreInfo.put("checkoutDir", childPath);
            moreInfo.put("pluginDir", childPath);
        }

        return moreInfo;
    }

    /**
     * Returns the list of plugins that belong to the multi module project that this hook is intended for
     */
    protected abstract List<String> getBundledPlugins();

    /**
     * Returns the folder where the multimodule project parent will be checked out
     */
    protected abstract String getParentFolder();

    /**
     * Returns the git url to checkout the multi module project
     */
    protected abstract String getParentUrl();

    /**
     * Returns the parent project name, this will be used to form the checkout tag with the format parentProjectName-version
     */
    protected abstract String getParentProjectName();

}
