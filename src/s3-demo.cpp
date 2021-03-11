// Based on: https://docs.aws.amazon.com/cloud9/latest/user-guide/sample-cplusplus.html
#include <iostream>
#include <aws/core/Aws.h>
#include <aws/s3/S3Client.h>
#include <aws/s3/model/Bucket.h>

bool ListBuckets(const Aws::S3::S3Client &s3Client)
{
    Aws::S3::Model::ListBucketsOutcome outcome = s3Client.ListBuckets();

    if (outcome.IsSuccess())
    {
        Aws::Vector<Aws::S3::Model::Bucket> bucket_list =
            outcome.GetResult().GetBuckets();

        for (Aws::S3::Model::Bucket const &bucket : bucket_list)
        {
            std::cout << bucket.GetName() << std::endl;
        }

        return true;
    }
    else
    {
        std::cout << "ListBuckets error: "
                  << outcome.GetError().GetMessage() << std::endl;
    }

    return false;
}

int main(int argc, char *argv[])
{

    if (argc < 2)
    {
        std::cout << "Usage: s3-demo <AWS Region>" << std::endl
                  << "Example: s3-demo us-east-1" << std::endl;
        return false;
    }

    Aws::SDKOptions options;
    Aws::InitAPI(options);
    {
        Aws::String region = argv[1];

        Aws::Client::ClientConfiguration config;

        // default region is N.Virginia
        if (region == "")
        {
            region = "us-east-1";
        }

        config.region = region;

        Aws::S3::S3Client s3_client(config);

        if (!ListBuckets(s3_client))
        {
            std::cout << "Failed to list buckets" << std::endl;
            return 1;
        }
    }
    Aws::ShutdownAPI(options);

    return 0;
}
