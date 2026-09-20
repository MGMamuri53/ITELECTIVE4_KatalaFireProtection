<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tbl_deliveryPickup', function (Blueprint $table) {
            $table->bigIncrements('v_deliveryPickupId');

            $table->unsignedBigInteger('v_orderId');

            $table->string('v_fulfillmentType', 20);

            $table->string('v_recipientName', 150)
                ->nullable();

            $table->string('v_recipientContactNumber', 30)
                ->nullable();

            $table->string('v_deliveryAddress', 255)
                ->nullable();

            $table->string('v_barangay', 100)
                ->nullable();

            $table->string('v_cityMunicipality', 100)
                ->nullable();

            $table->string('v_province', 100)
                ->nullable();

            $table->string('v_postalCode', 20)
                ->nullable();

            $table->string('v_pickupLocation', 255)
                ->nullable();

            $table->dateTime('v_scheduledDate')
                ->nullable();

            $table->dateTime('v_completedDate')
                ->nullable();

            $table->string('v_fulfillmentStatus', 50)
                ->nullable();

            $table->string('v_trackingReference', 100)
                ->nullable();

            $table->text('v_deliveryPickupNotes')
                ->nullable();

            $table->dateTime('v_createdAt')
                ->useCurrent();

            $table->dateTime('v_updatedAt')
                ->useCurrent();

            $table->foreign('v_orderId', 'fk_deliveryPickup_order')
                ->references('v_orderId')
                ->on('tbl_order')
                ->onUpdate('cascade')
                ->onDelete('cascade');
        });

        // PostgreSQL check constraint must be added
        // AFTER the table has been created.
        DB::statement(
            'ALTER TABLE "tbl_deliveryPickup"
             ADD CONSTRAINT "chk_deliveryPickup_fulfillmentType"
             CHECK ("v_fulfillmentType" IN (\'delivery\', \'pickup\'))'
        );
    }

    public function down(): void
    {
        Schema::dropIfExists('tbl_deliveryPickup');
    }
};