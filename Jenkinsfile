node('jessie-amd64')
{
    stage('Checkout')
    {
        // delete all previous remains
        //deleteDir()
        
        // freshly fetch all our goods from GitHub
        git branch: 'linux-vyos-4.19.y',
            url: 'https://github.com/vyos/vyos-kernel.git'
    }
}
